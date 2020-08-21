use Mix.Config

config :distribute_fibonacci,
  port: System.get_env("PORT", "4000")
