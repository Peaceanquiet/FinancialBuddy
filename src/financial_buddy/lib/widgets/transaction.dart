class Transaction {
  final String tID;
  final double tAmount;
  final String tCategory;
  final String tDescription;
  final DateTime tDate;

  Transaction(
    this.tID,
    this.tAmount,
    this.tCategory,
    this.tDate,
    this.tDescription,
  );
}
