// src/types.d.ts
declare module 'express' {
  export interface Request {
    body: any;
    params: any;
    query: any;
    file?: any;
    app: any;
  }
  export interface Response {
    status(code: number): Response;
    json(obj: any): Response;
    send(body?: any): Response;
  }
}

declare module 'uuid' {
  export function v4(): string;
}

declare module 'multer' {
  interface FileFilterCallback {
    (error: Error | null, acceptFile?: boolean): void;
  }
  
  interface File {
    fieldname: string;
    originalname: string;
    encoding: string;
    mimetype: string;
    size: number;
    destination: string;
    filename: string;
    path: string;
    buffer: Buffer;
  }
  
  interface Options {
    storage?: any;
    limits?: any;
    fileFilter?: any;
  }
  
  interface Multer {
    single(fieldname: string): any;
    array(fieldname: string, maxCount?: number): any;
    fields(fields: any[]): any;
    none(): any;
    any(): any;
  }
  
  function multer(options?: Options): Multer;
  
  namespace multer {
    interface DiskStorageOptions {
      destination?: any;
      filename?: any;
    }
    
    function diskStorage(options: DiskStorageOptions): any;
    
    interface FileFilterCallback {
      (error: Error | null, acceptFile?: boolean): void;
    }
  }
  
  export = multer;
}

declare namespace Express {
  export interface Multer {
    File: any;
  }
}