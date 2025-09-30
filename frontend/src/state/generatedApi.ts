import { api } from "./api";
const injectedRtkApi = api.injectEndpoints({
  endpoints: (build) => ({
    listLogs: build.query<ListLogsApiResponse, ListLogsApiArg>({
      query: () => ({ url: `/log` }),
    }),
    createLog: build.mutation<CreateLogApiResponse, CreateLogApiArg>({
      query: (queryArg) => ({
        url: `/log`,
        method: "POST",
        body: queryArg.logEntry,
      }),
    }),
  }),
  overrideExisting: false,
});
export { injectedRtkApi as enhancedApi };
export type ListLogsApiResponse =
  /** status 200 Successful Response */ LogEntryInDb[];
export type ListLogsApiArg = void;
export type CreateLogApiResponse =
  /** status 201 Successful Response */ LogEntryInDb;
export type CreateLogApiArg = {
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
export const { useListLogsQuery, useCreateLogMutation } = injectedRtkApi;
