import { Component, OnInit, ElementRef, ViewChild } from '@angular/core';
import { Http } from '@angular/http'

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})

export class AppComponent implements OnInit {
  constructor(private _httpService: Http) { }
  apiValues: {
    filterColumns: any[], filterOperators: any[], savedFilterSet: any[]
  };
  listColumns: any[];
  listOperators: any[];
  httpResponse: string;
  stagingFilter: { columnID: number, operatorID: number, value: any[] };
  isLoading: boolean;
  currResponseTab: string;
  @ViewChild('submitbtn') submitBtn: ElementRef;
  ngOnInit() {
    this.isLoading = true;
    this.currResponseTab = "debug";
    this._httpService.get('/api/values').subscribe(values => {
      this.apiValues = values.json();
      this.isLoading = false;
      this.stagingFilter = { columnID: -1, operatorID: -1, value: [] };
      console.log(this.apiValues);

      let propsColumns = Object.keys(this.apiValues.filterColumns);
      let propsOperators = Object.keys(this.apiValues.filterOperators);

      this.listColumns = [];
      this.listOperators = [];

      for (let prop of propsColumns) {
        if (prop && propsColumns[prop])
        this.listColumns.push(propsColumns[prop]);
      }

      for (let prop of propsOperators) {
        if (prop && propsOperators[prop])
          this.listOperators.push(propsOperators[prop]);
      }

      console.log(this.listOperators);
    });
  }

  changeResponseTab(newtab: string) {
    this.currResponseTab = newtab;
  }

  isCurrentTab(mytab: string) {
    return (mytab == this.currResponseTab);
  }

  getActiveClassForTab(mytab: string) {
    if (mytab == this.currResponseTab)
      return "active";
    else
      return "";
  }

  getActiveClassForTabContent(mytab: string) {
    if (mytab == this.currResponseTab)
      return "show active";
    else
      return "";
  }

  removeFilter(filterIndex: any) {
    this.apiValues.savedFilterSet.splice(filterIndex,1);
  }

  onChangeStagingColumn() {
    //this.stagingFilter.columnID = newID;
    console.log("selected new column: " + this.stagingFilter.columnID);
    //if (this.stagingOperator != undefined)
    //{
    //  this.stagingOperator.nativeElement.selectedIndex = 0;
    //  //console.log(this.stagingOperator);
    //  //console.log("index: " + this.stagingOperator.nativeElement.selectedIndex);
    //  //console.log("value: " + this.stagingOperator.nativeElement.value);
    //  this.stagingFilter.operatorID = this.stagingOperator.nativeElement.value;
    //}
  }
  onChangeStagingOperator() {
    //this.stagingFilter.operatorID = newID;
    console.log("selected new operator: " + this.stagingFilter.operatorID);
    this.stagingFilter.value = [];
    this.stagingFilter.value.push("");
  }
  AddFilter() {
    this.apiValues.savedFilterSet.push({ columnID: Number.parseInt(this.stagingFilter.columnID.toString()), operatorID: Number.parseInt(this.stagingFilter.operatorID.toString()), value: this.stagingFilter.value });
    this.stagingFilter = { columnID: -1, operatorID: -1, value: [] };
  }
  printJson(obj) {
    return JSON.stringify(obj);
  }
  submitFilter() {
    console.log("submitting:");
    console.log(this.apiValues.savedFilterSet);
    this.isLoading = true;
    this._httpService.post('/api/values', this.apiValues.savedFilterSet).subscribe(values => {
      console.log(values);
      this.httpResponse = values.json();
      this.isLoading = false;
      this.currResponseTab = "table";
    });
  }
}
