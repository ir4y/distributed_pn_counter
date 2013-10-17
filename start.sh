#!/bin/bash
rebar compile
erl -pa ebin deps/*/ebin -s counter

