import 'package:fluent_ui/fluent_ui.dart';

class MultiRowData {
  List<List<Widget>> rows;  // 所有行的组件
  List<int> order;          // 排序顺序索引

  MultiRowData(this.rows, {List<int>? initialOrder})
      : order = initialOrder ?? List.generate(rows.first.length, (i) => i);

  // 获取按当前顺序排列的行
  List<Widget> getOrderedRow(int rowIndex) {
    return order.map((index) => rows[rowIndex][index]).toList();
  }

  // 更新排序顺序
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
  }
}