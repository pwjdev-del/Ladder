.PHONY: bootstrap dev seed test lint clean backend-serve ios-build ios-test \
        isolation scheduling flags crypto help

help:
	@echo "Ladder make targets"
	@echo "  bootstrap        install prerequisites (XcodeGen, SwiftLint, Supabase CLI, Gitleaks)"
	@echo "  dev              start backend, seed, generate Xcode project, open simulator"
	@echo "  seed             load LWRPA + 2 family tenants into local Supabase"
	@echo "  test             run all test suites"
	@echo "  isolation        run cross-tenant attack suite (§4.2 P0)"
	@echo "  scheduling       run scheduling engine tests"
	@echo "  flags            run Varun dependency tests"
	@echo "  crypto           run envelope-crypto tests"
	@echo "  lint             SwiftLint + gitleaks + Deno fmt --check"
	@echo "  backend-serve    supabase start + functions serve"
	@echo "  ios-build        xcodebuild for iOS simulator"
	@echo "  clean            teardown local stack"

bootstrap:
	@command -v brew >/dev/null || (echo "install Homebrew first"; exit 1)
	brew install xcodegen swiftlint gitleaks supabase/tap/supabase deno || true
	cp -n .env.example .env || true
	@echo "bootstrap done — edit .env, then run 'make dev'"

dev:
	supabase start
	supabase db reset --local --no-seed
	supabase db push
	psql "$$SUPABASE_DB_URL" -f LadderBackend/supabase/seed.sql
	supabase functions serve --no-verify-jwt &
	xcodegen generate
	xed LadderApp.xcodeproj

seed:
	psql "$$SUPABASE_DB_URL" -f LadderBackend/supabase/seed.sql
	deno run -A scripts/seed-users.ts

backend-serve:
	supabase functions serve --no-verify-jwt

ios-build:
	xcodebuild -project LadderApp.xcodeproj \
	  -scheme LadderApp \
	  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
	  build | xcbeautify

ios-test:
	xcodebuild -project LadderApp.xcodeproj \
	  -scheme LadderApp \
	  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
	  test | xcbeautify

isolation:
	cd tests/isolation && pytest -x -v

scheduling:
	deno test tests/scheduling/ --allow-all

flags:
	deno test tests/flags/ --allow-all

crypto:
	deno test tests/crypto/ --allow-all

test: lint isolation scheduling flags crypto ios-test

lint:
	swiftlint lint --quiet
	gitleaks detect --no-git --verbose --redact
	deno fmt --check LadderBackend/

clean:
	supabase stop
	rm -rf build/ .build/ DerivedData/
