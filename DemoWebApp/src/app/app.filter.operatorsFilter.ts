import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filterSupportedOperators',
  pure: false
})

export class filterSupportedOperators implements PipeTransform {
  transform(items: any[], filtercollection: any[]): any {
    if (!items || !filtercollection) {
      return items;
    }

    return items.filter(item => filtercollection.indexOf(item.operatorID) !== -1);
  }
}
