import { existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';

// One local development server owns this file. Never silently replace damaged data.
export class LocalDatabase {
  constructor(file) {
    this.file = file;
    this.data = existsSync(file) ? JSON.parse(readFileSync(file, 'utf8')) : {version:1, accounts:[], documents:[]};
    if(this.data.version !== 1 || !Array.isArray(this.data.accounts) || !Array.isArray(this.data.documents)) throw new Error('Banco local inválido. Restaure o backup.');
  }
  save(section, value) {
    const next={...this.data,[section]:value};
    mkdirSync(dirname(this.file), {recursive:true});
    writeFileSync(this.file+'.tmp', JSON.stringify(next), {mode:0o600});
    renameSync(this.file+'.tmp',this.file);
    this.data=next;
  }
}
