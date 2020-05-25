import { Component, OnInit, Input } from '@angular/core';
import { MessageModel } from 'src/app/Shared/model';
import { Router } from '@angular/router';

@Component({
  selector: 'app-message-modal',
  templateUrl: './message-modal.component.html',
  styleUrls: ['./message-modal.component.css']
})
export class MessageModalComponent implements OnInit {

  static hiddenbutton: HTMLElement;
  static globalmessage: MessageModel;
  message: MessageModel = new MessageModel();
  
  constructor(private router: Router) { }
  ngOnInit() {
    MessageModalComponent.hiddenbutton = document.getElementById('hiddenbtn') as HTMLElement;
    this.getMessage();
  }

  getMessage(){
    this.message.Title = MessageModalComponent.globalmessage.Title;
    this.message.Content = MessageModalComponent.globalmessage.Content;
    this.message.BackToHome = MessageModalComponent.globalmessage.BackToHome;
  }

  Close(){
    if(this.message.BackToHome == true) this.router.navigate(['/home']);
  }
}
