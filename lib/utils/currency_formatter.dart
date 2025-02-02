String formatCurrency(double amount) {
  String formatted = amount.toStringAsFixed(2);
  String wholePart = formatted.split('.')[0];
  String decimalPart = formatted.split('.')[1];
  
  final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  wholePart = wholePart.replaceAllMapped(regex, (match) => '${match[1]}.');
  
  if (decimalPart == '00') {
    return '₺$wholePart';
  }
  
  return '₺$wholePart,$decimalPart';
} 