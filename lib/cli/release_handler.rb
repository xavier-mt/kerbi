module Kerbi
  module Cli
    class ReleaseHandler < BaseHandler

      cmd_meta Kerbi::Consts::CommandSchemas::INIT_RELEASE
      # @param [String] release_name refers to a Kubernetes namespace
      def init(release_name)
        mem_dna(release_name)
        state_backend.provision_missing_resources(verbose: run_opts.verbose?)
        ns_key = Kerbi::Consts::OptionSchemas::NAMESPACE
        Kerbi::ConfigFile.patch({ns_key => release_name})
      end

      cmd_meta Kerbi::Consts::CommandSchemas::RELEASE_STATUS
      def status(release_name)
        mem_dna(release_name)
        backend = state_backend
        backend.test_connection(verbose: run_opts.verbose?)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::RELEASE_LIST
      def list
        prep_opts(Kerbi::Consts::OptionDefaults::LIST_STATE)
        auth_bundle = Kerbi::Utils::Cli.make_k8s_auth_bundle(run_opts)
        backends = Kerbi::State::ConfigMapBackend.releases(auth_bundle)
        backends.each(&:prime)
        echo_data(backends, serializer: Kerbi::Cli::ReleaseSerializer)
      end

      cmd_meta Kerbi::Consts::CommandSchemas::RELEASE_DELETE
      def delete(release_name)
        mem_dna(release_name)
        backend = state_backend
        return unless user_confirmed?
        old_signature = backend.resource_signature
        backend.delete
        echo("Deleted #{old_signature}")
      end
    end
  end
end
