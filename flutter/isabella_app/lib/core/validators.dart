String? emailValidator(String? value) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) return 'Escribe tu correo';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Correo inválido';
  }
  return null;
}

String? passwordValidator(String? value) {
  if ((value ?? '').length < 6) return 'Mínimo 6 caracteres';
  return null;
}

String? requiredValidator(String? value, {String message = 'Campo obligatorio'}) {
  if ((value ?? '').trim().isEmpty) return message;
  return null;
}
