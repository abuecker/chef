#
# Author:: Bryan McLellan <btm@loftninjas.org>
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  module Mixin
    module PathHelpers
      def validate_path(path)
        if Chef::Platform.windows?
          validate_windows_path(path)
        else
          # TODO: might want this to noop
          raise Chef::Exceptions::UnsupportedPlatform.new(node[:platform])
        end
      end

      def native_path(path)
        # ALT_SEPARATOR is \\ on windows, nil on linux
        if ::File::ALT_SEPARATOR
          canonical_path(path).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
        else
          canonical_path(path)
        end
      end

      def native_windows_path(path)
        # Windows API calls often require an absolute path using backslashes, e.g. "C:\Program Files (x86)\Microsoft Office"
        canonical_path(path).gsub
      end

      def validate_windows_path(path)
        unless printable?(path)
          Chef::Log.warn("Path '#{path}' contains non-printable characters. Check that backslashes are escaped (C:\\\\Windows) in double-quoted strings.")
        end
      end

      def printable?(string)
        # returns true if string is free of non-printable characters (escape sequences)
        # this returns false for whitespace escape sequences as well, e.g. \n\t
        if string =~ /[^[:print:]]/ 
          false
        else
          true
        end
      end

      # Produce a comparable path. File.absolute_path does this for us.
      # This conveniently matches the case for filenames on Windows as well.
      def canonical_path(path)
        File.absolute_path(path)
      end

      def paths_eql?(path1, path2)
        canonical_path(path1) == canonical_path(path2)
      end
    end
  end
end
