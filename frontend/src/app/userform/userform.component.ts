import { Component, OnInit } from '@angular/core';
import { observable, Observable } from 'rxjs';
import { UserService } from '../user.service';

@Component({
  selector: 'userform',
  templateUrl: './userform.component.html',
  styleUrls: ['./userform.component.css']
})
export class UserformComponent implements OnInit {
  user = {
    name: 'Srinivas',
    age:10,
    dob: new Date()
    
  }
  signUpResponse:any;
  users:any[]=[];
    constructor(public userService: UserService) { }
  deleteUser(id:number){
    console.log(id);
    if(confirm("Are you sure")){
    const p = this.userService.delete(id);
    p.subscribe((responseBody:any)=>{
      console.log("Deleted success"+JSON.stringify(responseBody));
      this.users=responseBody;
         
  
    }),
    (error:any)=>{
      console.log(error);
    }}
  }
  saveUser(){
    console.log('clicked');
    const promise  = this.userService.save(this.user);
    promise.subscribe((responseBody:any)=>{
      console.log("response"+responseBody.id);
      //Document.getElementById("signup").style.display="none";
      this.signUpResponse=responseBody.message;
      this.users.push(responseBody);
      
    },
    (error:any)=>{
      this.signUpResponse=error.error.message;
      console.log("response error"+error+"sri"+JSON.stringify(this.signUpResponse));
    });
  }
  ngOnInit(): void {
    const observable= this.userService.getUsers();
    observable.subscribe((usersfromServer:any)=>{
      this.users=usersfromServer;
    });
    
  }

}