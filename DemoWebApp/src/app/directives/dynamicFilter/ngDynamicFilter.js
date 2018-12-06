class XArray extends Array {
    last() {
        return this[this.length - 1];
    }
    removeLastItem() {
        this.splice(-1, 1);
    }
}
class Directive {
    constructor() {
        this.restrict = 'E';
        this.templateUrl = function (element, attrs) {
            return attrs.templateUrl;
        };
        this.scope = {
            options: '=',
            config: '=',
            onSelect: '&'
        };
    }
    link($scope, elm, attr, ngModel) {
        $scope.apply = function () {
            var result = $scope.filters.getResult();
            $scope.onSelect({ result: result });
        };
        $scope.filters = new Filters($scope.apply);
        if ($scope.config && $scope.config.saveState) {
            $scope.filters.loadState($scope.options);
            $scope.apply();
        }
    }
    validate() {
        console.log(this);
    }
    static instance() {
        return new Directive();
    }
}
angular.module('ngDynamicFilter', []).directive('dynamicFilter', Directive.instance);
class Filter {
    constructor(callback) {
        this.values = new XArray();
        this.callback = callback;
    }
    addValue() {
        if (!this.canAddValue())
            return;
        this.values.push("");
    }
    canAddValue() {
        return this.values.last() && !this.isText();
    }
    onSelect(option) {
        this.option = option;
        this.values.push("");
    }
    checkOptionType(optionType) {
        if (!this.option)
            return false;
        return OptionType[this.option.type] == optionType.toString();
    }
    isAutocomplete() {
        return this.checkOptionType(OptionType.AUTOCOMPLETE);
    }
    isOptions() {
        return this.checkOptionType(OptionType.OPTIONS);
    }
    isText() {
        return this.checkOptionType(OptionType.TEXT);
    }
}
class Filters extends XArray {
    constructor(callback) {
        super();
        this.callback = callback;
    }
    add() {
        let lastFilter = this.last();
        if (lastFilter && !lastFilter.option)
            return;
        this.push(new Filter(this.callback));
    }
    getOptionByField(options, field) {
        let searchOption = options.filter(function (o) {
            return o.field == field;
        });
        if (searchOption.length == 0)
            throw ("Saved state value not found in options array!");
        return searchOption[0];
    }
    loadState(options) {
        var state = JSON.parse(localStorage.getItem('dynamicFilter'));
        var self = this;
        if (!state)
            return;
        state.forEach(function (s) {
            if (!s.values)
                return;
            self.add();
            let lastAddedFilter = self.last();
            let option = this.getOptionByField(options, s.option.field);
            lastAddedFilter.onSelect(option);
            s.values.forEach(function (v) {
                lastAddedFilter.addValue();
                lastAddedFilter.values[lastAddedFilter.values.length - 1] = v;
                var lastAddedFilterValue = lastAddedFilter.values.last();
                lastAddedFilterValue = v;
            });
        });
    }
    removeLast() {
        this.removeLastItem();
        this.callback();
    }
    isFilterSelected(option) {
        return this.some(function (f) {
            return f.option && f.option.field == option.field;
        });
    }
    isValueSelected(value) {
        return this.some(function (f) {
            return f.values && f.values.some && f.values.some(function (v) {
                return v.value == value;
            });
        });
    }
    getResult() {
        localStorage.setItem('dynamicFilter', JSON.stringify(this));
        return this.map(function (m) {
            var o = {};
            o[m.option.field] = m.values;
            return o;
        });
    }
}
var OptionType;
(function (OptionType) {
    OptionType[OptionType["TEXT"] = 0] = "TEXT";
    OptionType[OptionType["AUTOCOMPLETE"] = 1] = "AUTOCOMPLETE";
    OptionType[OptionType["OPTIONS"] = 2] = "OPTIONS";
})(OptionType || (OptionType = {}));
//# sourceMappingURL=concat.js.map