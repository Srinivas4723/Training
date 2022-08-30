import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';
import {HttpClientModule} from '@angular/common/http';
import { AppComponent } from './app.component';
import { UserformComponent } from './userform/userform.component';
import { UserService } from './user.service';
import { UserlistComponent } from './userlist/userlist.component';
//import { UserserviceComponent } from './userservice/userservice.component';

@NgModule({
  declarations: [
    AppComponent,
    UserformComponent,
    UserlistComponent,
  
  ],
  imports: [
    BrowserModule,FormsModule,HttpClientModule
    ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
