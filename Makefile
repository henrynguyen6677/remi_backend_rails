.PHONY:
dev:
	rails s
test:
	bundle exec rspec --format documentation 2>&1
