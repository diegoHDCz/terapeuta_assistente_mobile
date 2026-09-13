import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:terapeuta_assistente_mobile/core/common/entities/user.dart';
import 'package:terapeuta_assistente_mobile/core/common/widgets/cubits/app_user_cubit.dart';
import 'package:terapeuta_assistente_mobile/core/usecase/usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/usecases/current_user_usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:terapeuta_assistente_mobile/features/auth/domain/usecases/sign_up_with_google_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CurrentUserUsecase _currentUserUsecase;
  final LoginWithEmailUsecase _loginWithEmailUsecase;
  final SignUpWithEmailUsecase _signUpWithEmailUsecase;
  final LoginWithGoogleUsecase _loginWithGoogleUsecase;
  final SignUpWithGoogleUsecase _signUpWithGoogleUsecase;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required CurrentUserUsecase currentUserUsecase,
    required LoginWithEmailUsecase loginWithEmailUsecase,
    required SignUpWithEmailUsecase signUpWithEmailUsecase,
    required LoginWithGoogleUsecase loginWithGoogleUsecase,
    required SignUpWithGoogleUsecase signUpWithGoogleUsecase,
    required AppUserCubit appUserCubit,
  }) : _currentUserUsecase = currentUserUsecase,
       _loginWithEmailUsecase = loginWithEmailUsecase,
       _signUpWithEmailUsecase = signUpWithEmailUsecase,
       _loginWithGoogleUsecase = loginWithGoogleUsecase,
       _signUpWithGoogleUsecase = signUpWithGoogleUsecase,
       _appUserCubit = appUserCubit,
       super(AuthInitial()) {
    on<AuthIsUserLoggedIn>(_onIsUserLoggedIn);
    on<AuthLogin>(_onLogin);
    on<AuthSignUp>(_onSignUp);
    on<AuthLoginWithGoogle>(_onLoginWithGoogle);
    on<AuthSignUpWithGoogle>(_onSignUpWithGoogle);
  }

  Future<void> _onIsUserLoggedIn(AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    final result = await _currentUserUsecase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitSuccess(user, emit),
    );
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginWithEmailUsecase(
      LoginWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitSuccess(user, emit),
    );
  }

  Future<void> _onSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signUpWithEmailUsecase(
      SignUpWithEmailParams(name: event.name, email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitSuccess(user, emit),
    );
  }

  Future<void> _onLoginWithGoogle(AuthLoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginWithGoogleUsecase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitSuccess(user, emit),
    );
  }

  Future<void> _onSignUpWithGoogle(AuthSignUpWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signUpWithGoogleUsecase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitSuccess(user, emit),
    );
  }

  void _emitSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
