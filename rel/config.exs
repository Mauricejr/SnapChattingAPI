use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"CVE1LwL1_r_oxsMb{LShMg[wOR,(.y}r3OrcFvoUN/xR4{rxnkg*eO)Vv7<xqP6G"
end

environment :prod do
  set include_erts: true
  set include_src: false
  #set cookie: :"W&u=S$}^CsP~wffbG=OqM_=)z9LPw<nUjz4F%nu%J7=i6NezU]W2s^4VudP%NyK["
  set cookie: :"${MY_COOKIE}"
  set vm_args: "rel/vm.args"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :myFitnessSnapChatMessage do
  set version: current_version(:myFitnessSnapChatMessage)
end
