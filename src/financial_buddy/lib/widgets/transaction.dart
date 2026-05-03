class Transaction {
  final String tID;
  final double tAmount;
  final String tTitle;
  final String tCategory;
  final DateTime tDate;
  final String tAccount;    
  final String tAccountId;  
  final String tType;

  Transaction(
    this.tID,
    this.tAmount,
    this.tTitle,
    this.tCategory,
    this.tDate,
    this.tAccount,
    this.tAccountId,
    this.tType,
  );
}