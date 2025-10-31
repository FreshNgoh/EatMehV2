import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/story/story_model.dart';
import '../../../data/repositories/story_repository.dart';

// Events
abstract class StoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StoryLoadRequested extends StoryEvent {
  final List<String> friendIds;
  StoryLoadRequested(this.friendIds);

  @override
  List<Object?> get props => [friendIds];
}

class StoryCreateRequested extends StoryEvent {
  final StoryModel story;
  StoryCreateRequested(this.story);

  @override
  List<Object?> get props => [story];
}

class StoryViewMarked extends StoryEvent {
  final String storyId;
  final String userId;
  StoryViewMarked(this.storyId, this.userId);

  @override
  List<Object?> get props => [storyId, userId];
}

// States
abstract class StoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final List<StoryModel> stories;
  StoryLoaded(this.stories);

  @override
  List<Object?> get props => [stories];
}

class StoryError extends StoryState {
  final String message;
  StoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository storyRepository;

  StoryBloc({required this.storyRepository}) : super(StoryInitial()) {
    on<StoryLoadRequested>(_onStoryLoadRequested);
    on<StoryCreateRequested>(_onStoryCreateRequested);
    on<StoryViewMarked>(_onStoryViewMarked);
  }

  Future<void> _onStoryLoadRequested(
    StoryLoadRequested event,
    Emitter<StoryState> emit,
  ) async {
    emit(StoryLoading());

    try {
      await emit.forEach(
        storyRepository.getActiveStories(event.friendIds),
        onData: (stories) => StoryLoaded(stories),
        onError: (error, stackTrace) => StoryError(error.toString()),
      );
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onStoryCreateRequested(
    StoryCreateRequested event,
    Emitter<StoryState> emit,
  ) async {
    try {
      await storyRepository.createStory(event.story);
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onStoryViewMarked(
    StoryViewMarked event,
    Emitter<StoryState> emit,
  ) async {
    try {
      await storyRepository.markStoryAsViewed(event.storyId, event.userId);
    } catch (e) {
      // Silently fail
    }
  }
}
