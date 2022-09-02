import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

const URL ="http://localhost:8082/user"
@Injectable({//decorator
  providedIn: 'root'
})
export class UserService {
    delete(id: any){
        return this.http.delete(URL+"/delete/"+id)
    }
  save(user: any) {
    return this.http.post(URL,user);
  }
  getUsers(){
      return this.http.get(URL);
  }
  constructor(public http:HttpClient) { }

}