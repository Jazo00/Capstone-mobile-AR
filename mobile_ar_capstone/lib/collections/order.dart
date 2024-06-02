import 'package:isar/isar.dart';

part 'order.g.dart';

@Collection()
class Order {
  Id id = Isar.autoIncrement;

  @Index()
  late String customerId; //ID of customer that placed the order

  @Index()
  late String sellerId; //ID of seller that placed the order

  @Index()
  late int livestockId; //ID of livestock being ordered

  late DateTime orderDate;

  late String status; //"pending", "request_to_cancel", "confirmed", "cancelled"
}