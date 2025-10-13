import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_repo/trip_repo.dart';
import 'package:driver/app/bloc/trip_bloc.dart';
import 'package:driver/services/realtime/realtime_service.dart';

class MockTripRepo extends Mock implements TripRepo {}
class MockRealtimeService extends Mock implements RealtimeService {}

void main() {
  group('TripBloc', () {
    late MockTripRepo mockTripRepo;
    late MockRealtimeService mockRealtimeService;
    late TripBloc tripBloc;

    setUp(() {
      mockTripRepo = MockTripRepo();
      mockRealtimeService = MockRealtimeService();
      tripBloc = TripBloc(
        tripRepo: mockTripRepo,
        realtimeService: mockRealtimeService,
      );
    });

    tearDown(() {
      tripBloc.close();
    });

    test('initial state is TripState.initial', () {
      expect(tripBloc.state, equals(const TripState.initial()));
    });

    group('TripInitialized', () {
      blocTest<TripBloc, TripState>(
        'emits [initializing, idle] when no active trip exists',
        build: () {
          when(() => mockTripRepo.getActiveTrip()).thenAnswer(
            (_) async => const TripResponse(
              success: true,
              trip: null,
            ),
          );
          return tripBloc;
        },
        act: (bloc) => bloc.add(const TripInitialized()),
        expect: () => [
          const TripState(status: TripBlocStatus.initializing),
          const TripState(status: TripBlocStatus.idle),
        ],
      );

      blocTest<TripBloc, TripState>(
        'emits [initializing, onTrip] when active trip exists',
        build: () {
          const mockTrip = Trip(
            id: 'trip_123',
            status: TripStatus.accepted,
            pickupLocation: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Airport',
            ),
            dropLocation: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Central',
            ),
          );

          when(() => mockTripRepo.getActiveTrip()).thenAnswer(
            (_) async => const TripResponse(
              success: true,
              trip: mockTrip,
            ),
          );
          return tripBloc;
        },
        act: (bloc) => bloc.add(const TripInitialized()),
        expect: () => [
          const TripState(status: TripBlocStatus.initializing),
          const TripState(
            status: TripBlocStatus.onTrip,
            currentTrip: mockTrip,
          ),
        ],
      );
    });

    group('TripRequestReceived', () {
      const mockTripRequest = TripRequest(
        tripId: 'trip_123',
        pickup: TripLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          address: 'Mumbai Airport',
        ),
        drop: TripLocation(
          latitude: 19.0760,
          longitude: 72.8777,
          address: 'Mumbai Central',
        ),
        estimatedFare: 150.0,
        distanceKm: 15.5,
        expiresAt: null, // Will be set in test
        customer: CustomerInfo(
          maskedName: 'R. Kumar',
          maskedPhone: '+91-XXXXX1234',
        ),
      );

      blocTest<TripBloc, TripState>(
        'emits [incomingRequest] when trip request is received',
        build: () => tripBloc,
        act: (bloc) => bloc.add(
          TripRequestReceived(
            mockTripRequest.copyWith(
              expiresAt: DateTime.now().add(const Duration(seconds: 30)),
            ),
          ),
        ),
        expect: () => [
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.incomingRequest)
              .having((s) => s.incomingTrip?.tripId, 'tripId', 'trip_123'),
        ],
      );
    });

    group('TripAccepted', () {
      blocTest<TripBloc, TripState>(
        'emits [accepting, accepted] when trip is accepted successfully',
        build: () {
          when(() => mockTripRepo.acceptTrip('trip_123')).thenAnswer(
            (_) async => const TripResponse(
              success: true,
              trip: Trip(
                id: 'trip_123',
                status: TripStatus.accepted,
                pickupLocation: TripLocation(
                  latitude: 19.0760,
                  longitude: 72.8777,
                  address: 'Mumbai Airport',
                ),
                dropLocation: TripLocation(
                  latitude: 19.0760,
                  longitude: 72.8777,
                  address: 'Mumbai Central',
                ),
              ),
            ),
          );
          return tripBloc;
        },
        seed: () => const TripState(
          status: TripBlocStatus.incomingRequest,
          incomingTrip: TripRequest(
            tripId: 'trip_123',
            pickup: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Airport',
            ),
            drop: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Central',
            ),
            estimatedFare: 150.0,
            distanceKm: 15.5,
            expiresAt: null,
            customer: CustomerInfo(
              maskedName: 'R. Kumar',
              maskedPhone: '+91-XXXXX1234',
            ),
          ),
        ),
        act: (bloc) => bloc.add(const TripAccepted()),
        expect: () => [
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.accepting),
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.accepted)
              .having((s) => s.currentTrip?.id, 'currentTripId', 'trip_123')
              .having((s) => s.incomingTrip, 'incomingTrip', null),
        ],
      );

      blocTest<TripBloc, TripState>(
        'emits [error] when trip acceptance fails',
        build: () {
          when(() => mockTripRepo.acceptTrip('trip_123')).thenAnswer(
            (_) async => const TripResponse(
              success: false,
              message: 'Trip no longer available',
            ),
          );
          return tripBloc;
        },
        seed: () => const TripState(
          status: TripBlocStatus.incomingRequest,
          incomingTrip: TripRequest(
            tripId: 'trip_123',
            pickup: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Airport',
            ),
            drop: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Central',
            ),
            estimatedFare: 150.0,
            distanceKm: 15.5,
            expiresAt: null,
            customer: CustomerInfo(
              maskedName: 'R. Kumar',
              maskedPhone: '+91-XXXXX1234',
            ),
          ),
        ),
        act: (bloc) => bloc.add(const TripAccepted()),
        expect: () => [
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.accepting),
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', 'Trip no longer available'),
        ],
      );
    });

    group('TripRejected', () {
      blocTest<TripBloc, TripState>(
        'emits [idle] when trip is rejected',
        build: () {
          when(() => mockTripRepo.rejectTrip('trip_123', reason: 'Too far')).thenAnswer(
            (_) async => const TripResponse(success: true),
          );
          return tripBloc;
        },
        seed: () => const TripState(
          status: TripBlocStatus.incomingRequest,
          incomingTrip: TripRequest(
            tripId: 'trip_123',
            pickup: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Airport',
            ),
            drop: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Central',
            ),
            estimatedFare: 150.0,
            distanceKm: 15.5,
            expiresAt: null,
            customer: CustomerInfo(
              maskedName: 'R. Kumar',
              maskedPhone: '+91-XXXXX1234',
            ),
          ),
        ),
        act: (bloc) => bloc.add(const TripRejected(reason: 'Too far')),
        expect: () => [
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.idle)
              .having((s) => s.incomingTrip, 'incomingTrip', null),
        ],
      );
    });

    group('TripCompleted', () {
      blocTest<TripBloc, TripState>(
        'emits [completing, completed] when trip is completed successfully',
        build: () {
          when(() => mockTripRepo.completeTrip('trip_123')).thenAnswer(
            (_) async => const TripResponse(
              success: true,
              trip: Trip(
                id: 'trip_123',
                status: TripStatus.completed,
                pickupLocation: TripLocation(
                  latitude: 19.0760,
                  longitude: 72.8777,
                  address: 'Mumbai Airport',
                ),
                dropLocation: TripLocation(
                  latitude: 19.0760,
                  longitude: 72.8777,
                  address: 'Mumbai Central',
                ),
              ),
            ),
          );
          return tripBloc;
        },
        seed: () => const TripState(
          status: TripBlocStatus.onTrip,
          currentTrip: Trip(
            id: 'trip_123',
            status: TripStatus.inProgress,
            pickupLocation: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Airport',
            ),
            dropLocation: TripLocation(
              latitude: 19.0760,
              longitude: 72.8777,
              address: 'Mumbai Central',
            ),
          ),
        ),
        act: (bloc) => bloc.add(const TripCompleted()),
        expect: () => [
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.completing),
          isA<TripState>()
              .having((s) => s.status, 'status', TripBlocStatus.completed)
              .having((s) => s.completedTrip?.id, 'completedTripId', 'trip_123')
              .having((s) => s.currentTrip, 'currentTrip', null),
        ],
      );
    });
  });
}
