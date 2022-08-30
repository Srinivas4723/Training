import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';
import { UserService } from '../user.service';

@Component({
  selector: 'userform',
  templateUrl: './userform.component.html',
  styleUrls: ['./userform.component.css']
})
export class UserformComponent implements OnInit {
  user = {
    name: 'Srinivas',
    age: 10
  }
  users:any[]=[];
    constructor(public userService: UserService) { }

  saveUser(){
    console.log('clicked');
    const promise  = this.userService.save(this.user);
    promise.subscribe((responseBody:any)=>{
      console.log("response"+responseBody.id);
      this.users.push(responseBody);
      
    },
    (error:any)=>{
      console.log("response error"+error)
    });
  }
  ngOnInit(): void {
  }

}