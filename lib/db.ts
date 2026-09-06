import { Pool } from "pg";

// ponytail: process-wide pool; schema when passages exist
export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});
