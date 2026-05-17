#!/bin/bash

jekyll clean

#jekyll serve --watch --livereload --config _config.yml,_dev_config.yml


jekyll serve --incremental --force_polling --watch --livereload --config _config.yml,_dev_config.yml