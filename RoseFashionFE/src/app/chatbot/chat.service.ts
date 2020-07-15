import { Injectable } from '@angular/core';

import { environment } from '../../environments/environment';

// import { ApiAiClient } from 'api-ai-javascript';
import { ApiAiClient } from 'api-ai-javascript/es6/ApiAiClient'


import { Observable, BehaviorSubject } from 'rxjs';

export class Message {
  constructor(public content: string, public sentBy: string, public imgurl: string) {}
}
@Injectable({
  providedIn: 'root'
})
export class ChatService {
  readonly token = environment.dialogflow.angularBot;
  readonly client = new ApiAiClient({ accessToken: this.token });

  conversation = new BehaviorSubject<Message[]>([]);

  constructor() {}

  // Sends and receives messages via DialogFlow
  converse(msg: string) {
    const userMessage = new Message(msg, 'user', '');
    this.update(userMessage);
    
    return this.client.textRequest(msg)
               .then(res => {
                 //console.log(res);
                 var x = res.result.fulfillment.messages;
                 console.log(x);
                 if(x[1]){
                  const botMessage = new Message((String)(x[0].speech), 'bot',(String)(x[1].speech));
                  this.update(botMessage);
                 }
                 else{
                  const speech = res.result.fulfillment.speech;
                  const botMessage = new Message(speech, 'bot','');
                  this.update(botMessage);
                 }
               });
  }



  // Adds message to source
  update(msg: Message) {
    this.conversation.next([msg]);
  }
}
