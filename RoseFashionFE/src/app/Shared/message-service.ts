import { MessageModel } from './model';
import { MessageModalComponent } from '../Others/message-modal/message-modal.component';

export class MessageService{
    SendMessage(messagemodel: MessageModel){
        MessageModalComponent.globalmessage = messagemodel;
        MessageModalComponent.hiddenbutton.click();
    }
}