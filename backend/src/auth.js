import { randomBytes, scryptSync, timingSafeEqual, createHash } from 'node:crypto';
import { accountSchema } from './domain.js';

export function createDemoAuth(database=null) {
  const accounts=new Map(database?.data.accounts??[]), sessions=new Map();
  const persist=()=>database?.save('accounts',[...accounts]);
  const digest=value=>createHash('sha256').update(value).digest('hex');
  function login(body, register=false) {
    const input=accountSchema.parse(body);
    let account=accounts.get(input.email);
    let recoveryCode;
    if(register) {
      if(!input.name) throw Object.assign(new Error('Informe seu nome.'),{status:400});
      if(account) throw Object.assign(new Error('Não foi possível criar esta conta.'),{status:409});
      const salt=randomBytes(16).toString('hex');
      account={uid:randomBytes(16).toString('hex'),email:input.email,name:input.name,salt,hash:scryptSync(input.password,salt,64).toString('hex')};
      recoveryCode=randomBytes(16).toString('hex');
      account.recoveryHash=digest(recoveryCode);
      accounts.set(input.email,account);
      try { persist(); } catch(e) { accounts.delete(input.email); throw e; }
    } else if (!account || !timingSafeEqual(Buffer.from(account.hash,'hex'),scryptSync(input.password,account.salt,64))) {
      throw Object.assign(new Error('E-mail ou senha incorretos.'),{status:401});
    }
    const now=Date.now();
    for(const [token,session] of sessions) if(session.expires<now) sessions.delete(token);
    const token=randomBytes(32).toString('hex');
    const user={uid:account.uid,email:account.email,name:account.name,admin:account.admin===true};
    sessions.set(token,{user,expires:now+86400000});
    return {token,user,...(recoveryCode?{recoveryCode}:{})};
  }
  return {
    login,
    recoveryCode(user) {
      const account=accounts.get(user.email);
      if(!account || account.uid!==user.uid) throw Object.assign(new Error('Conta não encontrada.'),{status:404});
      const recoveryCode=randomBytes(16).toString('hex');
      accounts.set(user.email,{...account,recoveryHash:digest(recoveryCode)});
      try { persist(); } catch(e) { accounts.set(user.email,account); throw e; }
      return {recoveryCode};
    },
    recover(body) {
      const input=accountSchema.parse(body);
      const account=accounts.get(input.email);
      const supplied=typeof body.recoveryCode==='string'?digest(body.recoveryCode.trim()):'';
      if(!account?.recoveryHash || supplied!==account.recoveryHash) throw Object.assign(new Error('Confira o e-mail e o código de recuperação.'),{status:400});
      const salt=randomBytes(16).toString('hex');
      const recoveryCode=randomBytes(16).toString('hex');
      const updated={...account,salt,hash:scryptSync(input.password,salt,64).toString('hex'),recoveryHash:digest(recoveryCode)};
      accounts.set(input.email,updated);
      try { persist(); } catch(e) { accounts.set(input.email,account); throw e; }
      for(const [token,session] of sessions) if(session.user.uid===account.uid) sessions.delete(token);
      return {recoveryCode};
    },
    revoke: token => sessions.delete(token),
    verify: async token => {
      const session=sessions.get(token);
      if(!session || session.expires<Date.now()) throw new Error('Sessão expirada.');
      return session.user;
    },
  };
}

export function authenticate(verify) {
  return async (req,res,next) => {
    const token=req.headers.authorization?.match(/^Bearer (\S+)$/)?.[1];
    if(!token) return res.status(401).json({error:'Entre na sua conta para continuar.'});
    try { req.user=await verify(token); req.token=token; next(); }
    catch { res.status(401).json({error:'Sessão inválida ou expirada. Entre novamente.'}); }
  };
}
