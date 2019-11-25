import { Component, OnInit } from '@angular/core';
import { MessageModel } from 'src/app/model';

@Component({
  selector: 'app-message-modal',
  templateUrl: './message-modal.component.html',
  styleUrls: ['./message-modal.component.css']
})
export class MessageModalComponent implements OnInit {

  static hiddenbutton: HTMLElement;
  static globalmessage: MessageModel = { Type: '', Content: '', YesNoQuestion: false };
  constructor() { }

  ngOnInit() {
    MessageModalComponent.hiddenbutton = document.getElementById('hiddenbtn') as HTMLElement;
  }

  getGlobalMessageType() {
    return MessageModalComponent.globalmessage.Type;
  }

  getGlobalMessage() {
    return MessageModalComponent.globalmessage.Content;
  }

}
