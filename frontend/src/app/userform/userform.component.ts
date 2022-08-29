import { Component, OnInit } from '@angular/core';
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
  constructor(public userService: UserService) { }

  saveUser(){
    console.log('clicked');
    const promise = this.userService.save(this.user);
    promise.subscribe();
  }
  ngOnInit(): void {
  }

}