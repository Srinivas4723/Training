import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

const URL ="http://localhost:8082/user"
@Injectable({//decorator
  providedIn: 'root'
})
export class UserService {
  save(user: any) {
    return this.http.post(URL+"/age/34/height/160",user);
  }

  constructor(public http:HttpClient) { }

}