class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

String authErrorMessage(String code) {
  switch (code) {
    case 'weak-password':
      return 'La contraseña debe tener al menos 6 caracteres.';
    case 'email-already-in-use':
      return 'Ya existe una cuenta con ese correo.';
    case 'invalid-email':
      return 'El correo no es válido.';
    case 'user-not-found':
      return 'No existe una cuenta con ese correo.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Correo o contraseña incorrectos.';
    case 'user-disabled':
      return 'Esta cuenta está deshabilitada.';
    case 'too-many-requests':
      return 'Demasiados intentos. Espera un momento.';
    case 'popup-closed-by-user':
      return 'Se cerró la ventana de Google.';
    case 'popup-blocked':
      return 'El navegador bloqueó la ventana de Google. Permite las ventanas emergentes e inténtalo de nuevo.';
    case 'cancelled-popup-request':
      return 'Se canceló la solicitud de Google. Inténtalo de nuevo.';
    case 'network-request-failed':
      return 'Sin conexión. Revisa tu red.';
    default:
      return 'Ocurrió un error. Inténtalo de nuevo.';
  }
}
