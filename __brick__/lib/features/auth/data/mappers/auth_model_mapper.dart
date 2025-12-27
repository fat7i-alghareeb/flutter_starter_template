import '../../domain/entities/auth_entity.dart';
import '../models/auth_model.dart';

extension AuthModelMapper on AuthModel {
  AuthEntity get toEntity => AuthEntity(id: id);
}
