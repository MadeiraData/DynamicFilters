import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppComponent } from './app.component';

import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

import { filterSupportedOperators } from './app.filter.operatorsFilter';

@NgModule({
  declarations: [
    AppComponent,
    filterSupportedOperators
  ],
  imports: [
    BrowserModule,
      FormsModule,
      HttpModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
