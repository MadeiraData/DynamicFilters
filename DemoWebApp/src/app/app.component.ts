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
  stagingFilter: { columnID: any, operatorID: any, value: any[] };
  @ViewChild('so') stagingOperator: ElementRef;
  ngOnInit() {
    this._httpService.get('/api/values').subscribe(values => {
      this.apiValues = values.json();
      this.stagingFilter = { columnID: "", operatorID: "", value: [] };
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

  removeFilter(filterIndex: any) {
    this.apiValues.savedFilterSet.splice(filterIndex,1);
  }

  onChangeStagingColumn(newID) {
    this.stagingFilter.columnID = newID;
    console.log("selected new column: " + newID);
    if (this.stagingOperator != undefined)
    {
      this.stagingOperator.nativeElement.selectedIndex = 0;
      //console.log(this.stagingOperator);
      //console.log("index: " + this.stagingOperator.nativeElement.selectedIndex);
      //console.log("value: " + this.stagingOperator.nativeElement.value);
      this.stagingFilter.operatorID = this.stagingOperator.nativeElement.value;
    }
  }
  onChangeStagingOperator(newID) {
    this.stagingFilter.operatorID = newID;
    console.log("selected new operator: " + newID);
    if (this.apiValues.filterOperators[newID] != undefined && !this.apiValues.filterOperators[newID].isMultiValue)
      this.stagingFilter.value.push("");
    else
      this.stagingFilter.value = [];
  }
}
