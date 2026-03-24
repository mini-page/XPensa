String maskAmount(String value, {bool masked = false}) {
  return masked ? '••••' : value;
}
