#!/bin/bash

kubectl get node $1 --show-labels | awk '{ print $6 }' | tr ',' '\n'
