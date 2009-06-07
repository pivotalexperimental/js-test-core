module JsTestCore
  module Resources
    class File < Resource
      map "*"

      MIME_TYPES = {
        '.html' => 'text/html',
        '.htm' => 'text/html',
        '.js' => 'text/javascript',
        '.css' => 'text/css',
        '.png' => 'image/png',
        '.jpg' => 'image/jpeg',
        '.jpeg' => 'image/jpeg',
        '.gif' => 'image/gif',
        }

      get "*" do
        if ::File.exists?(absolute_path)
          extension = ::File.extname(absolute_path)
          content_type = MIME_TYPES[extension] || 'text/html'
          [
            200,
            {
              'Content-Type' => content_type,
              'Last-Modified' => ::File.mtime(absolute_path).rfc822,
              'Content-Length' => ::File.size(absolute_path)
            },
            ::File.read(absolute_path)
          ]
        else
          not_found
        end
      end
      
      def relative_path
        @relative_path ||= params["splat"]
      end

      def absolute_path
        @absolute_path ||= ::File.expand_path("#{public_path}#{relative_path.join("/")}")
      end

      protected

      def not_found
        body = Representations::NotFound.new(:path_info => request.path_info).to_s        
        [
          404,
          {
            "Content-Type" => "text/html",
            "Content-Length" => body.size.to_s
          },
          body
        ]
      end
    end
  end
end
