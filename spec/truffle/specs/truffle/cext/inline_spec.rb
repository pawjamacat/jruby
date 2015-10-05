# Copyright (c) 2015 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

require_relative '../../../../ruby/spec_helper'

describe "Truffle::CExt.inline" do
  
  if Truffle::CExt.supported?

    it "needs to be reviewed for spec completeness"

  else

    it "raises a RuntimeError" do
      lambda {
        Truffle::CExt.inline %{ #include <unistd.h> }, %{ getpid(); }
      }.should raise_error(RuntimeError)
    end

  end

end
