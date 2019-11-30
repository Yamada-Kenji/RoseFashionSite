import { Component, OnInit } from '@angular/core';
import { MessageModel } from 'src/app/Shared/model';

@Component({
  selector: 'app-message-modal',
  templateUrl: './message-modal.component.html',
  styleUrls: ['./message-modal.component.css']
})
export class MessageModalComponent implements OnInit {

  static hiddenbutton: HTMLElement;
  static globalmessage: MessageModel = { Title: '', Content: ''};
  constructor() { }

  ngOnInit() {
    MessageModalComponent.hiddenbutton = document.getElementById('hiddenbtn') as HTMLElement;
  }

  getGlobalMessageTitle() {
    return MessageModalComponent.globalmessage.Title;
  }

  getGlobalMessage() {
    return MessageModalComponent.globalmessage.Content;
  }

}
