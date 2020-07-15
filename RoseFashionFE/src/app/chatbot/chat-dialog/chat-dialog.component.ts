import { Component, OnInit,ViewChild} from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { ScrollToBottomDirective } from '../scroll-to-bottom.directive'

import { ChatService, Message } from '../chat.service';
import { Observable } from 'rxjs';

import { scan } from 'rxjs/operators';


@Component({
  selector: 'app-chat-dialog',
  templateUrl: './chat-dialog.component.html',
  styleUrls: ['./chat-dialog.component.css']
})
export class ChatDialogComponent implements OnInit {
  //@ViewChild(ScrollToBottomDirective)
  scroll: ScrollToBottomDirective;


  messages: Observable<Message[]>;
  formValue: string;
  showchat: boolean = false;

  constructor(public chat: ChatService) { }

  ngOnInit() {

    this.messages = this.chat.conversation.asObservable().pipe(
      scan((acc, val) => acc.concat(val) )
    );
    

  }

  sendMessage() {
    this.chat.converse(this.formValue);
    console.log(this.messages);
    this.formValue = '';
  }

  hidechat(){
    this.showchat = false;
  }
  showchatt(){
    this.showchat = true;
  }

}
