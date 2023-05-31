#!/usr/bin/env bats

# Executed before each test.
setup() {
  # Make sure the directory is clean.
  dfx start --clean --background
}

# executed after each test
teardown() {
  dfx stop
}

@test "The caller is not the creator" {
  dfx deploy
  run dfx canister call day3 writeMessage '(variant {"Text"="Test"})'
  [ "$output" == '(0 : nat)' ]
  run dfx --identity anonymous canister call day3 updateMessage '(0, variant {"Text"="Test2"})'
  [ "$output" == '(variant { err = "creator is not same" })' ]
}

