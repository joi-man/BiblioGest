import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/data/models/usuario.dart';
import 'package:frontend/features/auth/data/repositories/usuario_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/core/widgets/alertas.dart';

/// Formulario para crear un usuario o editar uno existente.
///
/// Avisa con [onGuardado] cuando el cambio se guardó, para que quien lo abrió
/// recargue sus listados.
class DialogoUsuario extends ConsumerStatefulWidget {
  final Usuario? usuario;
  final VoidCallback onGuardado;

  const DialogoUsuario({super.key, this.usuario, required this.onGuardado});

  @override
  ConsumerState<DialogoUsuario> createState() => _DialogoUsuarioState();
}

class _DialogoUsuarioState extends ConsumerState<DialogoUsuario> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _correoController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _documentoController;
  late TextEditingController _telefonoController;
  late TextEditingController _contrasenaController;
  late TextEditingController _confirmarContrasenaController;
  String _rol = 'estudiante';
  bool _guardando = false;
  bool _mostrarContrasena = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.usuario?.username ?? '',
    );
    _correoController = TextEditingController(
      text: widget.usuario?.correoElectronico ?? '',
    );
    _nombreController = TextEditingController(
      text: widget.usuario?.nombre ?? '',
    );
    _apellidoController = TextEditingController(
      text: widget.usuario?.apellido ?? '',
    );
    _documentoController = TextEditingController(
      text: widget.usuario?.numeroDocumento ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.usuario?.telefono ?? '',
    );
    _contrasenaController = TextEditingController();
    _confirmarContrasenaController = TextEditingController();
    if (widget.usuario != null) {
      _rol = widget.usuario!.rol;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _correoController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.usuario != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  esEdicion ? 'Editar Usuario' : 'Nuevo Usuario',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  maxLength: 50,
                  enabled: !esEdicion,
                  decoration: const InputDecoration(
                    labelText: 'Username *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El username es obligatorio';
                    }
                    if (value.length < 3) {
                      return 'Minimo 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  maxLength: 255,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electronico *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    if (!value.contains('@')) {
                      return 'Correo invalido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apellidoController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Apellido *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El apellido es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _documentoController,
                  maxLength: 20,
                  keyboardType: TextInputType.number,
                  // Sin puntos ni espacios: 4111222, no 4.111.222.
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z-]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Numero de documento * (sin puntos)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El documento es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  maxLength: 20,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefono',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _rol,
                  decoration: const InputDecoration(
                    labelText: 'Rol *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'estudiante',
                      child: Text('Estudiante'),
                    ),
                    DropdownMenuItem(
                      value: 'bibliotecario',
                      child: Text('Bibliotecario'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _rol = value ?? 'estudiante';
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  esEdicion
                      ? 'Dejar vacio para no cambiar contrasena'
                      : 'Contrasena *',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contrasenaController,
                  obscureText: !_mostrarContrasena,
                  decoration: InputDecoration(
                    labelText: esEdicion
                        ? 'Nueva contrasena (opcional)'
                        : 'Contrasena',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarContrasena
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarContrasena = !_mostrarContrasena;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (!esEdicion && (value == null || value.isEmpty)) {
                      return 'La contrasena es obligatoria';
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Minimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarContrasenaController,
                  obscureText: !_mostrarContrasena,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contrasena',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!esEdicion && (value == null || value.isEmpty)) {
                      return 'Confirma la contrasena';
                    }
                    if (_contrasenaController.text.isNotEmpty &&
                        value != _contrasenaController.text) {
                      return 'Las contrasenas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final token = ref.read(authProvider).value?.accessToken;
      if (token == null) return;

      final repo = ref.read(usuarioRepositoryProvider);
      final esEdicion = widget.usuario != null;

      if (!esEdicion) {
        await repo.crear({
          'username': _usernameController.text.trim(),
          'correo_electronico': _correoController.text.trim(),
          'contrasena': _contrasenaController.text,
          'numero_documento': _documentoController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'rol': _rol,
          'telefono': _telefonoController.text.trim().isEmpty
              ? null
              : _telefonoController.text.trim(),
        }, token);
      } else {
        final datos = {
          'correo_electronico': _correoController.text.trim(),
          'numero_documento': _documentoController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'rol': _rol,
          // Vacio borra el telefono (null significaria "no cambiar").
          'telefono': _telefonoController.text.trim(),
          if (_contrasenaController.text.isNotEmpty)
            'contrasena': _contrasenaController.text,
        };
        await repo.actualizar(widget.usuario!.id, datos, token);
      }

      widget.onGuardado();
      if (mounted) Navigator.pop(context);
      if (mounted) {
        context.mostrarExito(
          esEdicion ? 'Usuario actualizado' : 'Usuario creado',
        );
      }
    } catch (e) {
      if (mounted) context.mostrarError('Error: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}
