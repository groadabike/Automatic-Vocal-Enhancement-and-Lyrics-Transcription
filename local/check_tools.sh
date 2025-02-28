#!/bin/bash -u

# Copyright 2015 (c) Johns Hopkins University (Jan Trmal <jtrmal@gmail.com>)

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
# WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
# MERCHANTABLITY OR NON-INFRINGEMENT.
# See the Apache 2 License for the specific language governing permissions and
# limitations under the License.

[ -f ./path.sh ] && . ./path.sh

command -v uconv &>/dev/null \
  || { echo  >&2 "uconv not found on PATH. You will have to install ICU4C"; exit 1; }

command -v ngram &>/dev/null \
  || { echo  >&2 "srilm not found on PATH. Please use the script $KALDI_ROOT/tools/extras/install_srilm.sh to install it"; exit 1; }

if [  -z ${LIBLBFGS} ]; then
  echo >&2  "SRILM is not compiled with the support of MaxEnt models."
  echo >&2  "You should use the script in \$KALDI_ROOT/tools/install_srilm.sh"
  echo >&2  "which will take care of compiling the SRILM with MaxEnt support"
  exit 1;
fi

sox=`command -v sox 2>/dev/null` \
  || { echo  >&2 "sox not found on PATH. Please install it manually (you will need version 14.4.0 and higher)."; exit 1; }

# If sox is found on path, check if the version is correct
if [ ! -z "$sox" ]; then
  sox_version=`$sox --version 2>&1| head -1 | sed -e 's?.*: ??' -e 's?.* ??'`
  if [[ ! $sox_version =~ v14.4.* ]]; then
    echo "Unsupported sox version $sox_version found on path. You will need version v14.4.0 and higher."
    exit 1
  fi
fi

command -v phonetisaurus-align &>/dev/null \
  || { echo  >&2 "Phonetisaurus not found on PATH. Please use the script $KALDI_ROOT/tools/extras/install_phonetisaurus.sh to install it"; exit 1; }

miniconda_dir=$HOME/miniconda3/
if [ ! -d $miniconda_dir ]; then
    echo "$miniconda_dir does not exist. Please run '../../../tools/extras/install_miniconda.sh'"
fi

# Install dependencies
# SoundFile
result=`$miniconda_dir/bin/python -c "\
try:
    import soundfile
    print('1')
except ImportError:
    print('0')"`

if [ "$result" != "1" ]; then
  ${miniconda_dir}/bin/python -m pip install soundfile
fi

# Asteroid
result=`$miniconda_dir/bin/python -c "\
try:
    import asteroid
    print('1')
except ImportError:
    print('0')"`

if [ "$result" != "1" ]; then
    ${miniconda_dir}/bin/python -m pip install asteroid==0.3.3
fi

#parselmouth

result=`$miniconda_dir/bin/python -c "\
try:
    import parselmouth
    print('1')
except ImportError:
    print('0')"`

if [ "$result" != "1" ]; then
  ${miniconda_dir}/bin/python -m pip install praat-parselmouth
fi

fmmpeg_conda=`command -v ${miniconda_dir}/bin/ffmpeg 2>/dev/null`
if [ -z "${fmmpeg_conda}" ]; then
  echo "install conda ffmpeg (v4.3.1)"
  ${miniconda_dir}/bin/conda install -c conda-forge ffmpeg -n base
fi

exit 0


