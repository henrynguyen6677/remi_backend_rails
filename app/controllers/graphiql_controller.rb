class GraphiqlController < ApplicationController
  def index
    render html: <<~HTML.html_safe
      <!DOCTYPE html>
      <html>
        <head>
          <title>GraphiQL</title>
          <link rel="stylesheet" href="https://unpkg.com/graphiql@3/graphiql.min.css" />
        </head>
        <body style="margin:0">
          <div id="graphiql" style="height:100vh"></div>
          <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
          <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
          <script crossorigin src="https://unpkg.com/graphiql@3/graphiql.min.js"></script>
          <script>
            const root = ReactDOM.createRoot(document.getElementById('graphiql'));
            root.render(
              React.createElement(GraphiQL, {
                fetcher: GraphiQL.createFetcher({ url: '/graphql' }),
                defaultEditorToolsVisibility: true,
              })
            );
          </script>
        </body>
      </html>
    HTML
  end
end

