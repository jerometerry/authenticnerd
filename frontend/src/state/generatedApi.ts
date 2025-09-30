import { api } from "./api";
const injectedRtkApi = api.injectEndpoints({
  endpoints: (build) => ({
    listLogsLogsGet: build.query<
      ListLogsLogsGetApiResponse,
      ListLogsLogsGetApiArg
    >({
      query: () => ({ url: `/logs/` }),
    }),
    createLogLogsPost: build.mutation<
      CreateLogLogsPostApiResponse,
      CreateLogLogsPostApiArg
    >({
      query: (queryArg) => ({
        url: `/logs/`,
        method: "POST",
        body: queryArg.logEntry,
      }),
    }),
  }),
  overrideExisting: false,
});
export { injectedRtkApi as enhancedApi };
export type ListLogsLogsGetApiResponse =
  /** status 200 Successful Response */ LogEntryInDb[];
export type ListLogsLogsGetApiArg = void;
export type CreateLogLogsPostApiResponse =
  /** status 201 Successful Response */ LogEntryInDb;
export type CreateLogLogsPostApiArg = {
  logEntry: LogEntry;
};
export type LogEntryInDb = {
  content: string;
  mood: number;
  _id: string | null;
};
export type ValidationError = {
  loc: (string | number)[];
  msg: string;
  type: string;
};
export type HttpValidationError = {
  detail?: ValidationError[];
};
export type LogEntry = {
  content: string;
  mood: number;
};
export const { useListLogsLogsGetQuery, useCreateLogLogsPostMutation } =
  injectedRtkApi;
