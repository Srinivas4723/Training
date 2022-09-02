import { Component, OnInit } from '@angular/core';
import { UserService } from '../user.service';
@Component({
  selector: 'userlist',
  templateUrl: './userlist.component.html',
  styleUrls: ['./userlist.component.css']
})
export class UserlistComponent implements OnInit {

  constructor(public userService:UserService) { }
  users:any[]=[];
  ngOnInit(): void {
    const observable= this.userService.getUsers();
    observable.subscribe((usersfromServer:any)=>{
      this.users=usersfromServer;
    });
  }

}
