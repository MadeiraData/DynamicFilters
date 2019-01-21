(window["webpackJsonp"] = window["webpackJsonp"] || []).push([["main"],{

/***/ "./src/$$_lazy_route_resource lazy recursive":
/*!**********************************************************!*\
  !*** ./src/$$_lazy_route_resource lazy namespace object ***!
  \**********************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

function webpackEmptyAsyncContext(req) {
	// Here Promise.resolve().then() is used instead of new Promise() to prevent
	// uncaught exception popping up in devtools
	return Promise.resolve().then(function() {
		var e = new Error("Cannot find module '" + req + "'");
		e.code = 'MODULE_NOT_FOUND';
		throw e;
	});
}
webpackEmptyAsyncContext.keys = function() { return []; };
webpackEmptyAsyncContext.resolve = webpackEmptyAsyncContext;
module.exports = webpackEmptyAsyncContext;
webpackEmptyAsyncContext.id = "./src/$$_lazy_route_resource lazy recursive";

/***/ }),

/***/ "./src/app/app.component.css":
/*!***********************************!*\
  !*** ./src/app/app.component.css ***!
  \***********************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = ".glyphicon-refresh-animate {\r\n  -animation: spin .7s infinite linear;\r\n  -webkit-animation: spin2 .7s infinite linear;\r\n}\r\n\r\n@-webkit-keyframes spin2 {\r\n  from {\r\n    -webkit-transform: rotate(0deg);\r\n  }\r\n\r\n  to {\r\n    -webkit-transform: rotate(360deg);\r\n  }\r\n}\r\n\r\n@-webkit-keyframes spin {\r\n  from {\r\n    -webkit-transform: scale(1) rotate(0deg);\r\n            transform: scale(1) rotate(0deg);\r\n  }\r\n\r\n  to {\r\n    -webkit-transform: scale(1) rotate(360deg);\r\n            transform: scale(1) rotate(360deg);\r\n  }\r\n}\r\n\r\n@keyframes spin {\r\n  from {\r\n    -webkit-transform: scale(1) rotate(0deg);\r\n            transform: scale(1) rotate(0deg);\r\n  }\r\n\r\n  to {\r\n    -webkit-transform: scale(1) rotate(360deg);\r\n            transform: scale(1) rotate(360deg);\r\n  }\r\n}\r\n\r\n/*# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInNyYy9hcHAvYXBwLmNvbXBvbmVudC5jc3MiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUE7RUFDRSxxQ0FBcUM7RUFDckMsNkNBQTZDO0NBQzlDOztBQUVEO0VBQ0U7SUFDRSxnQ0FBZ0M7R0FDakM7O0VBRUQ7SUFDRSxrQ0FBa0M7R0FDbkM7Q0FDRjs7QUFFRDtFQUNFO0lBQ0UseUNBQWlDO1lBQWpDLGlDQUFpQztHQUNsQzs7RUFFRDtJQUNFLDJDQUFtQztZQUFuQyxtQ0FBbUM7R0FDcEM7Q0FDRjs7QUFSRDtFQUNFO0lBQ0UseUNBQWlDO1lBQWpDLGlDQUFpQztHQUNsQzs7RUFFRDtJQUNFLDJDQUFtQztZQUFuQyxtQ0FBbUM7R0FDcEM7Q0FDRiIsImZpbGUiOiJzcmMvYXBwL2FwcC5jb21wb25lbnQuY3NzIiwic291cmNlc0NvbnRlbnQiOlsiLmdseXBoaWNvbi1yZWZyZXNoLWFuaW1hdGUge1xyXG4gIC1hbmltYXRpb246IHNwaW4gLjdzIGluZmluaXRlIGxpbmVhcjtcclxuICAtd2Via2l0LWFuaW1hdGlvbjogc3BpbjIgLjdzIGluZmluaXRlIGxpbmVhcjtcclxufVxyXG5cclxuQC13ZWJraXQta2V5ZnJhbWVzIHNwaW4yIHtcclxuICBmcm9tIHtcclxuICAgIC13ZWJraXQtdHJhbnNmb3JtOiByb3RhdGUoMGRlZyk7XHJcbiAgfVxyXG5cclxuICB0byB7XHJcbiAgICAtd2Via2l0LXRyYW5zZm9ybTogcm90YXRlKDM2MGRlZyk7XHJcbiAgfVxyXG59XHJcblxyXG5Aa2V5ZnJhbWVzIHNwaW4ge1xyXG4gIGZyb20ge1xyXG4gICAgdHJhbnNmb3JtOiBzY2FsZSgxKSByb3RhdGUoMGRlZyk7XHJcbiAgfVxyXG5cclxuICB0byB7XHJcbiAgICB0cmFuc2Zvcm06IHNjYWxlKDEpIHJvdGF0ZSgzNjBkZWcpO1xyXG4gIH1cclxufVxyXG4iXX0= */"

/***/ }),

/***/ "./src/app/app.component.html":
/*!************************************!*\
  !*** ./src/app/app.component.html ***!
  \************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = "<h1>Demo Web App</h1>\r\n\r\n\r\n<div class=\"form-group\">\r\n  <div class=\"input-group\" *ngFor=\"let f of apiValues.savedFilterSet; index as i\">\r\n    <div class=\"input-group-prepend\">\r\n      <span class=\"input-group-text\"><strong>{{apiValues.filterColumns[f.columnID].displayName}}</strong></span>\r\n    </div>\r\n    <span class=\"input-group-text\">{{apiValues.filterOperators[f.operatorID].name}}:</span>\r\n    <span class=\"form-control\">{{f.value}}</span>\r\n    <div class=\"input-group-append\">\r\n      <button class=\"btn btn-outline-secondary\" type=\"button\" (click)=\"removeFilter(i)\" title=\"Remove\">&times;</button>\r\n    </div>\r\n  </div>\r\n  <div class=\"input-group\">\r\n    <button type=\"button\" class=\"btn btn-success\" (click)=\"submitFilter()\">Submit</button>\r\n  </div>\r\n</div>\r\n\r\n<div class=\"form-group\">\r\n  <div class=\"input-group\">\r\n    <select class=\"form-control\" [(ngModel)]=\"stagingFilter.columnID\" (change)=\"onChangeStagingColumn()\">\r\n      <option [ngValue]=\"-1\" selected=\"selected\">Add condition on...</option>\r\n      <option *ngFor=\"let c of listColumns; index as i\" [ngValue]=\"c\">{{apiValues.filterColumns[c].displayName}}</option>\r\n    </select>\r\n\r\n    <select class=\"form-control\" (change)=\"onChangeStagingOperator()\" *ngIf=\"stagingFilter.columnID!==''&&stagingFilter.columnID!==-1\" [(ngModel)]=\"stagingFilter.operatorID\">\r\n      <option *ngFor=\"let op of apiValues.filterColumns[stagingFilter.columnID].supportedFilterOperators; index as i\" [ngValue]=\"op\">{{apiValues.filterOperators[op].name}}</option>\r\n    </select>\r\n\r\n    <input class=\"form-control\" *ngIf=\"apiValues.filterOperators[stagingFilter.operatorID] != undefined && apiValues.filterOperators[stagingFilter.operatorID].isMultiValue==false && apiValues.filterColumns[stagingFilter.columnID].availableValues.length == 0\" [(ngModel)]=\"stagingFilter.value[0]\" />\r\n\r\n    <select class=\"form-control\" *ngIf=\"apiValues.filterOperators[stagingFilter.operatorID] != undefined && apiValues.filterOperators[stagingFilter.operatorID].isMultiValue==false && apiValues.filterColumns[stagingFilter.columnID].availableValues.length > 0\" [(ngModel)]=\"stagingFilter.value[0]\">\r\n      <option *ngFor=\"let v of apiValues.filterColumns[stagingFilter.columnID].availableValues; index as i\" [ngValue]=\"v.value\">{{v.label}}</option>\r\n    </select>\r\n\r\n    <select class=\"form-control\" *ngIf=\"apiValues.filterOperators[stagingFilter.operatorID] != undefined && apiValues.filterOperators[stagingFilter.operatorID].isMultiValue==true && apiValues.filterColumns[stagingFilter.columnID].availableValues.length > 0\" multiple=\"multiple\" [(ngModel)]=\"stagingFilter.value\">\r\n      <option *ngFor=\"let v of apiValues.filterColumns[stagingFilter.columnID].availableValues; index as i\" [ngValue]=\"v.value\">{{v.label}}</option>\r\n    </select>\r\n\r\n    <button #submitbtn type=\"button\" class=\"btn btn-outline-primary\" *ngIf=\"apiValues.filterOperators[stagingFilter.operatorID] != undefined && apiValues.filterColumns[stagingFilter.columnID] != undefined && stagingFilter.value[0] != undefined\" (click)=\"AddFilter()\">+</button>\r\n  </div>\r\n  <div>\r\n\r\n  </div>\r\n</div>\r\n<div *ngIf=\"isLoading\">Loading...</div>\r\n\r\n<br />\r\n<fieldset>\r\n  <legend>Debug:</legend>\r\n  <div>Operator ID: {{stagingFilter.operatorID }}</div>\r\n  <div *ngIf=\"apiValues.filterOperators[stagingFilter.operatorID] != undefined\">\r\n    Is Multi value: {{ apiValues.filterOperators[stagingFilter.operatorID].isMultiValue }}<br />\r\n    Available Values: <span *ngFor=\"let v of apiValues.filterColumns[stagingFilter.columnID].availableValues\">{{v.value}};</span><br />\r\n    Values: <span *ngFor=\"let v of stagingFilter.value\">{{v}};</span><br />\r\n  </div>\r\n  <div>Filter Body:</div>\r\n  <pre style=\"overflow:auto; white-space:pre-wrap; word-wrap:break-word; background-color: lightgray\">{{printJson(apiValues.savedFilterSet)}}</pre>\r\n  <div>Response Body:</div>\r\n  <pre style=\"overflow:auto; white-space:pre-wrap; word-wrap:break-word; background-color: lightgray\">{{printJson(httpResponse)}}</pre>\r\n</fieldset>\r\n<!--\r\n<ul class=\"list-group\">\r\n  <li class=\"list-group-item\" *ngFor='let fc of apiValues.filterColumns'>\r\n    <div class=\"input-group\" *ngIf='fc.supportedFilterOperators[0]!=\"\"'>\r\n\r\n      <select class=\"select2 form-control\">\r\n        <option *ngFor=\"let pr of apiValues.filterOperators | filterSupportedOperators:fc.supportedFilterOperators\" value=\"pr.OperatorID\">{{pr.name}}</option>\r\n      </select>\r\n\r\n  <input type=\"text\" />\r\n\r\n    </div>\r\n  </li>\r\n</ul>\r\n<script>\r\n  $(\".select2\").select2({\r\n    tags: true\r\n  })\r\n</script>\r\n-->\r\n"

/***/ }),

/***/ "./src/app/app.component.ts":
/*!**********************************!*\
  !*** ./src/app/app.component.ts ***!
  \**********************************/
/*! exports provided: AppComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "AppComponent", function() { return AppComponent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _angular_http__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @angular/http */ "./node_modules/@angular/http/fesm5/http.js");



var AppComponent = /** @class */ (function () {
    function AppComponent(_httpService) {
        this._httpService = _httpService;
    }
    AppComponent.prototype.ngOnInit = function () {
        var _this = this;
        this.isLoading = true;
        this._httpService.get('/api/values').subscribe(function (values) {
            _this.apiValues = values.json();
            _this.isLoading = false;
            _this.stagingFilter = { columnID: -1, operatorID: -1, value: [] };
            console.log(_this.apiValues);
            var propsColumns = Object.keys(_this.apiValues.filterColumns);
            var propsOperators = Object.keys(_this.apiValues.filterOperators);
            _this.listColumns = [];
            _this.listOperators = [];
            for (var _i = 0, propsColumns_1 = propsColumns; _i < propsColumns_1.length; _i++) {
                var prop = propsColumns_1[_i];
                if (prop && propsColumns[prop])
                    _this.listColumns.push(propsColumns[prop]);
            }
            for (var _a = 0, propsOperators_1 = propsOperators; _a < propsOperators_1.length; _a++) {
                var prop = propsOperators_1[_a];
                if (prop && propsOperators[prop])
                    _this.listOperators.push(propsOperators[prop]);
            }
            console.log(_this.listOperators);
        });
    };
    AppComponent.prototype.removeFilter = function (filterIndex) {
        this.apiValues.savedFilterSet.splice(filterIndex, 1);
    };
    AppComponent.prototype.onChangeStagingColumn = function () {
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
    };
    AppComponent.prototype.onChangeStagingOperator = function () {
        //this.stagingFilter.operatorID = newID;
        console.log("selected new operator: " + this.stagingFilter.operatorID);
        this.stagingFilter.value = [];
        this.stagingFilter.value.push("");
    };
    AppComponent.prototype.AddFilter = function () {
        this.apiValues.savedFilterSet.push({ columnID: Number.parseInt(this.stagingFilter.columnID.toString()), operatorID: Number.parseInt(this.stagingFilter.operatorID.toString()), value: this.stagingFilter.value });
        this.stagingFilter = { columnID: -1, operatorID: -1, value: [] };
    };
    AppComponent.prototype.printJson = function (obj) {
        return JSON.stringify(obj);
    };
    AppComponent.prototype.submitFilter = function () {
        var _this = this;
        console.log("submitting:");
        console.log(this.apiValues.savedFilterSet);
        this.isLoading = true;
        this._httpService.post('/api/values', this.apiValues.savedFilterSet).subscribe(function (values) {
            console.log(values);
            _this.httpResponse = values.json();
            _this.isLoading = false;
        });
    };
    tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["ViewChild"])('submitbtn'),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:type", _angular_core__WEBPACK_IMPORTED_MODULE_1__["ElementRef"])
    ], AppComponent.prototype, "submitBtn", void 0);
    AppComponent = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Component"])({
            selector: 'app-root',
            template: __webpack_require__(/*! ./app.component.html */ "./src/app/app.component.html"),
            styles: [__webpack_require__(/*! ./app.component.css */ "./src/app/app.component.css")]
        }),
        tslib__WEBPACK_IMPORTED_MODULE_0__["__metadata"]("design:paramtypes", [_angular_http__WEBPACK_IMPORTED_MODULE_2__["Http"]])
    ], AppComponent);
    return AppComponent;
}());



/***/ }),

/***/ "./src/app/app.filter.operatorsFilter.ts":
/*!***********************************************!*\
  !*** ./src/app/app.filter.operatorsFilter.ts ***!
  \***********************************************/
/*! exports provided: filterSupportedOperators */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "filterSupportedOperators", function() { return filterSupportedOperators; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");


var filterSupportedOperators = /** @class */ (function () {
    function filterSupportedOperators() {
    }
    filterSupportedOperators.prototype.transform = function (items, filtercollection) {
        if (!items || !filtercollection) {
            return items;
        }
        return items.filter(function (item) { return filtercollection.indexOf(item.operatorID) !== -1; });
    };
    filterSupportedOperators = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_1__["Pipe"])({
            name: 'filterSupportedOperators',
            pure: false
        })
    ], filterSupportedOperators);
    return filterSupportedOperators;
}());



/***/ }),

/***/ "./src/app/app.module.ts":
/*!*******************************!*\
  !*** ./src/app/app.module.ts ***!
  \*******************************/
/*! exports provided: AppModule */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "AppModule", function() { return AppModule; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "./node_modules/tslib/tslib.es6.js");
/* harmony import */ var _angular_platform_browser__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/platform-browser */ "./node_modules/@angular/platform-browser/fesm5/platform-browser.js");
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _app_component__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./app.component */ "./src/app/app.component.ts");
/* harmony import */ var _angular_forms__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @angular/forms */ "./node_modules/@angular/forms/fesm5/forms.js");
/* harmony import */ var _angular_http__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @angular/http */ "./node_modules/@angular/http/fesm5/http.js");
/* harmony import */ var _app_filter_operatorsFilter__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./app.filter.operatorsFilter */ "./src/app/app.filter.operatorsFilter.ts");







var AppModule = /** @class */ (function () {
    function AppModule() {
    }
    AppModule = tslib__WEBPACK_IMPORTED_MODULE_0__["__decorate"]([
        Object(_angular_core__WEBPACK_IMPORTED_MODULE_2__["NgModule"])({
            declarations: [
                _app_component__WEBPACK_IMPORTED_MODULE_3__["AppComponent"],
                _app_filter_operatorsFilter__WEBPACK_IMPORTED_MODULE_6__["filterSupportedOperators"]
            ],
            imports: [
                _angular_platform_browser__WEBPACK_IMPORTED_MODULE_1__["BrowserModule"],
                _angular_forms__WEBPACK_IMPORTED_MODULE_4__["FormsModule"],
                _angular_http__WEBPACK_IMPORTED_MODULE_5__["HttpModule"]
            ],
            providers: [],
            bootstrap: [_app_component__WEBPACK_IMPORTED_MODULE_3__["AppComponent"]]
        })
    ], AppModule);
    return AppModule;
}());



/***/ }),

/***/ "./src/environments/environment.ts":
/*!*****************************************!*\
  !*** ./src/environments/environment.ts ***!
  \*****************************************/
/*! exports provided: environment */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "environment", function() { return environment; });
// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.
var environment = {
    production: false
};
/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.


/***/ }),

/***/ "./src/main.ts":
/*!*********************!*\
  !*** ./src/main.ts ***!
  \*********************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _angular_core__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @angular/core */ "./node_modules/@angular/core/fesm5/core.js");
/* harmony import */ var _angular_platform_browser_dynamic__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @angular/platform-browser-dynamic */ "./node_modules/@angular/platform-browser-dynamic/fesm5/platform-browser-dynamic.js");
/* harmony import */ var _app_app_module__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./app/app.module */ "./src/app/app.module.ts");
/* harmony import */ var _environments_environment__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./environments/environment */ "./src/environments/environment.ts");




if (_environments_environment__WEBPACK_IMPORTED_MODULE_3__["environment"].production) {
    Object(_angular_core__WEBPACK_IMPORTED_MODULE_0__["enableProdMode"])();
}
Object(_angular_platform_browser_dynamic__WEBPACK_IMPORTED_MODULE_1__["platformBrowserDynamic"])().bootstrapModule(_app_app_module__WEBPACK_IMPORTED_MODULE_2__["AppModule"])
    .catch(function (err) { return console.error(err); });


/***/ }),

/***/ 0:
/*!***************************!*\
  !*** multi ./src/main.ts ***!
  \***************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(/*! C:\Users\user\Source\Repos\FilterParseSearchParameters\DemoWebApp\src\main.ts */"./src/main.ts");


/***/ })

},[[0,"runtime","vendor"]]]);
//# sourceMappingURL=main.js.map