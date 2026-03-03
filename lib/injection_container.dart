import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/websocket_client.dart';
import 'features/auctions/data/datasources/auction_local_datasource.dart';
import 'features/auctions/data/datasources/auction_remote_datasource.dart';
import 'features/auctions/data/repositories/auction_repository_impl.dart';
import 'features/auctions/domain/repositories/auction_repository.dart';
import 'features/auctions/domain/usecases/get_auction_detail_usecase.dart';
import 'features/auctions/domain/usecases/get_auctions_usecase.dart';
import 'features/auctions/domain/usecases/place_bid_usecase.dart';
import 'features/auctions/domain/usecases/watch_auction_usecase.dart';
import 'features/auctions/presentation/bloc/auction_detail_bloc.dart';
import 'features/auctions/presentation/bloc/auction_list_bloc.dart';
import 'features/auctions/presentation/bloc/bidding_bloc.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/notifications/notification_service.dart';
import 'features/profile/presentation/bloc/locale_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Core
  sl.registerLazySingleton(() => WebSocketClient());
  sl.registerLazySingleton(() => NotificationService());

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(auth: sl()),
  );
  sl.registerLazySingleton<AuctionRemoteDatasource>(
    () => AuctionRemoteDatasourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AuctionLocalDatasource>(
    () => AuctionLocalDatasourceImpl(prefs: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<AuctionRepository>(
    () => AuctionRepositoryImpl(remote: sl(), local: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetAuctionsUseCase(sl()));
  sl.registerLazySingleton(() => GetAuctionDetailUseCase(sl()));
  sl.registerLazySingleton(() => PlaceBidUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuctionUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => LocaleBloc(sl<SharedPreferences>()));

  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        repository: sl(),
      ));

  sl.registerFactory(() => AuctionListBloc(
        getAuctions: sl(),
      ));

  sl.registerFactory(() => AuctionDetailBloc(
        getAuctionDetail: sl(),
        watchAuction: sl(),
        repository: sl(),
      ));

  sl.registerFactory(() => BiddingBloc(
        getAuctionDetail: sl(),
        placeBid: sl(),
        watchAuction: sl(),
      ));
}
