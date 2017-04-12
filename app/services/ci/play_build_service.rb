module Ci
  class PlayBuildService < ::BaseService
    def execute(build)
      unless can?(current_user, :play_build, build)
        raise Gitlab::Access::AccessDeniedError
      end

      # Try to enqueue thebuild, otherwise create a duplicate.
      #
      if build.enqueue
        build.tap { |action| action.update(user: current_user) }
      else
        Ci::Build.retry(build, current_user)
      end
    end
  end
end
