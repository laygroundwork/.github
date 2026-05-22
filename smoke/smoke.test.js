import { test } from "node:test";
import assert from "node:assert/strict";

test("smoke workspace runs node --test under node-ci-reusable", () => {
  assert.equal(1 + 1, 2);
});
